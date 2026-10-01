import { LOCAL_STORAGE_KEYS } from "@/common/Constant";
import { TypedEventListenerOrEventListenerObject } from "@/common/EventTarget";
import { Logger, log } from "@/common/Logger";
import { TypedWorkerMessage, WorkerMessage, WorkerMessageType } from "@/worker";

let workerURL: string | null;
const isSafari = import.meta.env.VITE_APP_SAFARI === "true";
const SAFARI_WORKER_READY_TIMEOUT = 5000;
const SAFARI_WORKER_START_ATTEMPTS = 2;

const workerLog = new Logger();
workerLog.setContextName("Worker/Pipe");

let worker: SharedWorker | null = null;

type WorkerAddrMap = Record<string, string>;

async function init(originURL: string): Promise<SharedWorker> {
	// Check for existing url
	// If it exists, we'll connect to it
	const appVersion = import.meta.env.VITE_APP_VERSION;
	const workerAddrData: string | null = localStorage.getItem(LOCAL_STORAGE_KEYS.WORKER_ADDR);
	let workerAddr: WorkerAddrMap | null = null;

	try {
		workerAddr = workerAddrData ? JSON.parse(workerAddrData) : null;
	} catch (err) {
		log.error("Unable to parse worker address data", String(err));
		localStorage.removeItem(LOCAL_STORAGE_KEYS.WORKER_ADDR);
	}

	// A blob URL can outlive its SharedWorker registration in Safari's page
	// storage. Reusing that URL may reconnect to a worker that WebKit no longer
	// launches, leaving the app waiting for INIT until Safari is restarted.
	workerURL = !isSafari && typeof workerAddr === "object" && workerAddr !== null ? workerAddr[appVersion] : null;

	const ok =
		workerURL &&
		(await fetch(workerURL)
			.then((res) => res.ok)
			.catch(() => false));

	// Fetch worker data
	if (!ok) {
		// Get the offline URL passed by the loader
		workerURL = originURL;
		if (!workerURL) {
			log.error("Unable to find address to worker");
		}

		// Fetch worker data
		const data = await fetch(workerURL || "")
			.then((r) => r.blob())
			.catch((err) => {
				log.error("Unable to fetch worker data", err);
			});
		if (!data) return Promise.reject("There was an error fetching worker data");

		log.info("Received worker data", `(${data.size} bytes)`);

		// Create BLOB URL for worker & set it into local storage
		workerURL = URL.createObjectURL(data);
		if (!isSafari) {
			localStorage.setItem(
				LOCAL_STORAGE_KEYS.WORKER_ADDR,
				JSON.stringify({ ...(workerAddr ?? {}), [appVersion]: workerURL }),
			);
		}
	} else {
		log.info("Connecting to existing worker", `addr=${workerURL}`);
	}

	if (!workerURL) return Promise.reject("No address to worker");

	const sw = startWorker(workerURL, 1);

	// Emit close on page exit
	addEventListener("beforeunload", () => {
		sendMessage("CLOSE", {});
	});

	return sw;
}

function startWorker(url: string, attempt: number): SharedWorker {
	// A unique Safari name prevents WebKit from matching a new page to a stale
	// SharedWorker registration. Other browsers retain the existing shared
	// worker behavior across tabs.
	const name = isSafari ? `seventv-extension-safari-${Date.now()}-${attempt}` : "seventv-extension";
	const sw = new SharedWorker(url, { name });
	worker = sw;

	// Install listeners before starting the port so a fast INIT message cannot
	// be dispatched between port.start() and listener registration.
	useGlobalHandlers(sw.port);
	useHandlers(sw.port);

	if (isSafari) {
		let ready = false;
		const onMessage = (ev: MessageEvent) => {
			if (ev.data?.type !== "INIT") return;

			ready = true;
			sw.port.removeEventListener("message", onMessage);
		};
		sw.port.addEventListener("message", onMessage);

		setTimeout(() => {
			if (ready || worker !== sw) return;

			sw.port.removeEventListener("message", onMessage);
			sw.port.close();

			if (attempt < SAFARI_WORKER_START_ATTEMPTS) {
				log.warn("Safari worker did not become ready; retrying with a fresh registration");
				startWorker(url, attempt + 1);
			} else {
				log.error("Safari worker did not become ready after retrying");
			}
		}, SAFARI_WORKER_READY_TIMEOUT);
	}

	sw.port.start();
	return sw;
}

function sendMessage<T extends WorkerMessageType>(type: T, data: TypedWorkerMessage<T>): void {
	if (!worker) return;

	worker.port.postMessage({
		type: type,
		data: data,
	});
}

export function useWorker() {
	return {
		init,
		sendMessage,
		target: events,
	};
}

function useGlobalHandlers(chan: MessagePort) {
	chan.addEventListener("message", (ev) => {
		const { type, data } = ev.data;

		switch (type) {
			case "LOG": {
				const { type, text, css, objects } = data as TypedWorkerMessage<"LOG">;
				(text as string[]).splice(1, 0, "%c[Worker]%c");
				(css as string[]).splice(1, 0, ...Array(2).fill("color: #ca32fc;font-weight:900"));

				workerLog["print"](type, text, css, objects);
				break;
			}
		}
	});
}

function useHandlers(mp: MessagePort) {
	mp.addEventListener("message", (ev) => {
		const { type, data } = ev.data as WorkerMessage<WorkerMessageType>;

		switch (type) {
			case "INIT": {
				events.emit("ready", {});
				break;
			}
			case "CONFIG": {
				events.emit("config", data as TypedWorkerMessage<"CONFIG">);

				break;
			}
			case "IDENTITY_FETCHED": {
				const { user } = data as TypedWorkerMessage<"IDENTITY_FETCHED">;

				events.emit("identity_fetched", { user });
				break;
			}
			case "CHANNEL_FETCHED": {
				const { channel } = data as TypedWorkerMessage<"CHANNEL_FETCHED">;

				events.emit("channel_fetched", channel);
				break;
			}
			case "CHANNEL_SETS_FETCHED": {
				const { channel } = data as TypedWorkerMessage<"CHANNEL_SETS_FETCHED">;

				events.emit("channel_sets_fetched", channel);
				break;
			}
			case "COSMETIC_CREATED": {
				const cosmetic = data as TypedWorkerMessage<"COSMETIC_CREATED">;

				events.emit("cosmetic_created", cosmetic);
				break;
			}
			case "ENTITLEMENT_CREATED": {
				const entitlement = data as TypedWorkerMessage<"ENTITLEMENT_CREATED">;

				events.emit("entitlement_created", entitlement);
				break;
			}
			case "ENTITLEMENT_DELETED": {
				const entitlement = data as TypedWorkerMessage<"ENTITLEMENT_DELETED">;

				events.emit("entitlement_deleted", entitlement);
				break;
			}
			case "STATIC_COSMETICS_FETCHED": {
				const { badges, paints } = data as TypedWorkerMessage<"STATIC_COSMETICS_FETCHED">;

				events.emit("static_cosmetics_fetched", { badges, paints });
				break;
			}
			case "SYNC_TWITCH_SET": {
				const { out } = data as TypedWorkerMessage<"SYNC_TWITCH_SET">;
				if (!out) return;

				events.emit("twitch_emote_set_data", out);
				break;
			}
			case "EMOTE_SET_UPDATED":
				events.emit("emote_set_updated", data as TypedWorkerMessage<"EMOTE_SET_UPDATED">);
				break;
			case "USER_UPDATED":
				events.emit("user_updated", data as TypedWorkerMessage<"USER_UPDATED">);
				break;
		}
	});
}

class WorkletTarget extends EventTarget {
	constructor() {
		super();
	}

	addEventListener<T extends WorkletEventName>(
		type: T,
		listener: TypedEventListenerOrEventListenerObject<WorkletEvent<T>> | null,
		options?: boolean | AddEventListenerOptions,
	): void {
		super.addEventListener(type, listener as EventListenerOrEventListenerObject, options);
	}

	removeEventListener<T extends WorkletEventName>(
		type: T,
		listener: TypedEventListenerOrEventListenerObject<WorkletEvent<T>> | null,
		options?: boolean | EventListenerOptions,
	): void {
		super.removeEventListener(type, listener as EventListenerOrEventListenerObject, options);
	}

	dispatchEvent<T extends WorkletEventName>(event: WorkletEvent<T>): boolean {
		return super.dispatchEvent(event);
	}

	emit<T extends WorkletEventName>(type: T, data: WorkletTypedEvent<T>) {
		this.dispatchEvent(new CustomEvent(type, { detail: data }));
	}

	/**
	 * Listen until callback returns true
	 *
	 * @param name event name
	 * @param cb event callback
	 **/
	async listenUntil<T extends WorkletEventName>(name: T, cb: (ev: WorkletEvent<T>) => boolean) {
		await new Promise<void>((resolve) => {
			this.addEventListener(name, (ev) => {
				if (!cb(ev)) return;
				this.removeEventListener(name, cb);
				resolve();
			});
		});
	}
}

export type WorkletEventName =
	| "ready"
	| "config"
	| "identity_fetched"
	| "channel_fetched"
	| "channel_sets_fetched"
	| "cosmetic_created"
	| "entitlement_created"
	| "entitlement_deleted"
	| "static_cosmetics_fetched"
	| "twitch_emote_set_data"
	| "emote_set_updated"
	| "user_updated";

type WorkletTypedEvent<EVN extends WorkletEventName> = {
	ready: object;
	config: TypedWorkerMessage<"CONFIG">;
	identity_fetched: TypedWorkerMessage<"IDENTITY_FETCHED">;
	channel_fetched: CurrentChannel;
	channel_sets_fetched: CurrentChannel;
	cosmetic_created: Pick<SevenTV.Cosmetic, "id" | "data" | "kind">;
	entitlement_created: Pick<SevenTV.Entitlement, "id" | "kind" | "ref_id" | "user_id" | "platform_id">;
	entitlement_deleted: Pick<SevenTV.Entitlement, "id" | "kind" | "ref_id" | "user_id" | "platform_id">;
	static_cosmetics_fetched: Pick<TypedWorkerMessage<"STATIC_COSMETICS_FETCHED">, "badges" | "paints">;
	twitch_emote_set_data: SevenTV.EmoteSet;
	emote_set_updated: TypedWorkerMessage<"EMOTE_SET_UPDATED">;
	user_updated: TypedWorkerMessage<"USER_UPDATED">;
}[EVN];

export class WorkletEvent<T extends WorkletEventName> extends CustomEvent<WorkletTypedEvent<T>> {
	constructor(type: T, data: WorkletTypedEvent<T>) {
		super(type, { detail: data });
	}
}

const events = new WorkletTarget();
