{{flutter_js}}
{{flutter_build_config}}

const serviceWorkerVersion = {{flutter_service_worker_version}};
const flutterConfig = {
  canvasKitBaseUrl: "canvaskit/",
};

if (serviceWorkerVersion != null) {
  _flutter.loader.load({
    serviceWorkerSettings: {
      serviceWorkerVersion: serviceWorkerVersion,
    },
    config: flutterConfig,
  });
} else {
  _flutter.loader.load({config: flutterConfig});
}
