export default {
    // The port which PixelWeb will bind its web server to.
    // Default: 3000
    port: 3000,
    updater: {
        // Should the updater be enabled? You should leave this on unless your server does not have an internet connection.
        // Default: true
        enable: true,

        // The source where PixelWeb will pull new IPFS data from.
        // Default: https://devjakob.webs.vc/launcher/api/ipfs
        source: "https://devjakob.webs.vc/launcher/api/ipfs",

        // The interval at which PixelWeb should pull new information. Unit is in minutes
        // Default: 5 (update each 5 minutes)
        interval: 5,
    },
};
