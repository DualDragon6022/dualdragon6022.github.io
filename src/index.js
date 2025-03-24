import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import config from "./../config.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.disable("x-powered-by");

app.use(express.static(path.join(__dirname, "..", "public")));

// Current included information. May change at any time. Use the update service!
let ipfsData = {
    v1_8_8: {
        wasm: {
            cid: "QmQjrEWAoryALx5x3EZfQdsKBejdrZf3myNSLDQNn16YrY",
            size: 13146104,
        },
        js: {
            cid: "QmdxmaUT87vwsJPwZknQdDt3NGbQex9754PATfzaQkiCqA",
            size: 14531831,
        },
    },
    v1_12_2: {
        wasm: {
            cid: "QmP4q5mJKuxNvjsxQT5MaaExJNPr7hjziiD6LmZcjgWWPT",
            size: 16832305,
        },
        js: {
            cid: "QmNTuDdEi2AMFYjQ4DsbXrnZfwwYDN5DKtCP1wFBbdBsPN",
            size: 17387570,
        },
    },
};

// Basic IPFS response for launcher and providing data for other urls
app.get("/api/ipfs", (req, res) => {
    res.setHeader("Content-Type", "application/javascript");
    res.setHeader(
        "Cache-Control",
        "no-store, no-cache, must-revalidate, proxy-revalidate"
    );
    res.setHeader("Pragma", "no-cache");
    res.setHeader("Expires", "0");

    res.send(ipfsData);
});

app.use((req, res, next) => {
    res.status(404)
        .header("Content-Type", "text/plain")
        .sendFile(path.join(__dirname, "..", "public", "404.html"));
});

// Get the app to listen
const listenPort = config.port || 3000;
app.listen(listenPort, () => {
    console.log("[+] PixelWeb is listening on port " + listenPort);
});

// Update service
(() => {
    const updaterConfig = config.updater || undefined;
    if (updaterConfig) {
        let updateInterval = (config.updater.interval || 5) * 60 * 1000;
        let updateURL = config.updater.source || undefined;
        if (updateInterval < 30000) {
            console.error(
                "[!] [Updater] The update interval is set to under 30 seconds.\n" +
                    "[!] [Updater] Please do not try to bypass this warning and instead increase your update interval to reduce server load.\n" +
                    "[!] [Updater] Thanks."
            );
            return;
        }
        if (!updateURL) {
            console.error(
                "[!] [Updater] The update url was empty or not defined. The update service was disabled."
            );
            return;
        }
        console.log("[+] [Updater] Update service is enabled.");

        const runUpdateService = async () => {
            console.log("[+] [Updater] Attempting to update data.");

            try {
                let response = await fetch(updateURL);
                if (!response.ok)
                    throw new Error(`HTTP error! Status: ${response.status}`);
                let data = await response.json();

                ipfsData = data;
                console.log("[+] [Updater] Data has been updated.");
            } catch (error) {
                console.error("[!] [Updater] Fetch error:", error);
            }
        };

        runUpdateService(); // Want to pull data immediately after boot.
        setInterval(runUpdateService, updateInterval);
    } else {
        console.warn(
            "[!] Update service is disabled. IPFS data may turn invalid at any point."
        );
    }
})();
