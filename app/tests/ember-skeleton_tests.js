require('nrt-webui/core');

module("nrt-webui");

test("App is defined", function () {
  ok(typeof App !== 'undefined', "App is undefined");
});
