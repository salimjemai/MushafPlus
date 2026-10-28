{{flutter_js}}
{{flutter_build_config}}

// Flutter's own (deprecated) service worker is not registered: index.html
// registers coi-serviceworker.js at the same scope, and a second registration
// would replace it.
_flutter.loader.load({});
