'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "4f9b4d64d7fdd9c9cb8c008c7f880607",
"assets/assets/edgeDetectionSampleImages/apple.PNG": "780d818a0ab345706216ca7789387495",
"assets/assets/edgeDetectionSampleImages/bird.PNG": "1af62554819f1b26c3d1246d679e2602",
"assets/assets/edgeDetectionSampleImages/heart.PNG": "ce94f5c4dc2ab3b6a53ab98559eb7408",
"assets/assets/edgeDetectionSampleImages/jump.PNG": "85b5df365642286cbeace79a48fe2bbf",
"assets/assets/edgeDetectionSampleImages/leaf.PNG": "8ec4bdfc7f641b91a7b06f170a7b68f5",
"assets/assets/edgeDetectionSampleImages/mountain.PNG": "a2dc699e80742714cf2dd934ff3f409c",
"assets/assets/html/acs_for_edge_detection.html": "58445a1ab157c52b36673c5ad2118c5f",
"assets/assets/html/acs_for_job_scheduling.html": "bbdce831bb1cc108d36576fb530ad580",
"assets/assets/html/ant_colony_optimisation.html": "f1b167cc6961fd6cc68bb18585fe4fc7",
"assets/assets/html/ant_colony_system.html": "38eb0372c00f3fc8cfa4f9ef9b81a0d0",
"assets/assets/html/ant_system.html": "46da75024de03b83f56de23411319be2",
"assets/assets/html/credits.html": "6ed34c06369c5b4330ce71476841d70a",
"assets/assets/html/edge_detection.html": "1556a22c09b9d2b690417ab8562251d2",
"assets/assets/html/image_graph_representation.html": "a4ca1e73300dfa37f57bbee4a51ad0c0",
"assets/assets/html/job_description_format.html": "c5e4f88e90514f4ab9620d5d3ae87f7f",
"assets/assets/html/job_scheduling_problem.html": "98c62c59b29164d77472315278891701",
"assets/assets/html/jsp_graph_representation.html": "fd22463c62e67c7339ed050c7b8ccd7f",
"assets/assets/html/max_min_ant_system.html": "3a891fd771af819cc0c673c0f5420916",
"assets/assets/html/traveling_salesman_problem.html": "123e9e90729707216398452c0b7bc1eb",
"assets/assets/html/tsp_graph_representation.html": "3a6a0b2898235cb84797df501af533fa",
"assets/assets/images/aco.PNG": "a222bef768b12b109fbe64ef5b9d83a9",
"assets/assets/images/ACSdelta.PNG": "18fce5afb231983ea69ae6b8cda342cb",
"assets/assets/images/ACSdestinationSelectMethod1.PNG": "129b3e69fb2e3a03893fc907ab6a9133",
"assets/assets/images/ACSdestinationSelectMethod2.PNG": "57c7885f9753127fb2f438186dfca78f",
"assets/assets/images/ACSimgPrHeuristic.PNG": "8f03478a78ee24130422d9d6afb38b60",
"assets/assets/images/ACSimgPrIntensityVariation.PNG": "584363eee2a0fd11c96dd56d8e8aa23e",
"assets/assets/images/ACSimgPrLocalUpdate.PNG": "3f80095f6835874de7d9f8a11f7f05cc",
"assets/assets/images/ACSimgPrOfflineUpdate.PNG": "6d5a69c5a44876c602177de910d88571",
"assets/assets/images/ACSimgPrProba.PNG": "039beb85f10e94fc277ffb30b0afd4bb",
"assets/assets/images/ACSlocalUpdate.PNG": "97c713faf530843b72909176cd70dea7",
"assets/assets/images/ACSofflineUpdate.PNG": "cca72538afa297e250063a867f45e299",
"assets/assets/images/ACS_JSP_heuristicInfo.PNG": "da93fee10def25ebe9e97cc6e5768f83",
"assets/assets/images/ACS_JSP_machineDelay.PNG": "342524eb1b45e253885e267cb9b16f90",
"assets/assets/images/ACS_JSP_proba.PNG": "46cc8ec051554f649e3cd36f4665cda3",
"assets/assets/images/algoAS.PNG": "e4d7395c55948b5a4c449eca8215410e",
"assets/assets/images/cityProba.PNG": "cc8522dcf746cff68bbc5ab16fc06c3f",
"assets/assets/images/graphTSP.PNG": "23f98fb8caec6f03813c9ed179e3b1c4",
"assets/assets/images/imageGraph.PNG": "4baedffe83f2b5548c6ed1f54db59a58",
"assets/assets/images/jobDescription.PNG": "347e528a0bcd037c92e20ca9c33ad192",
"assets/assets/images/JSPgraph.PNG": "30e8e489e78092dffde5f4f7ba39688e",
"assets/assets/images/JSPgraphPath.PNG": "28addfc6913c2bb1f6e20b9c8f408d77",
"assets/assets/images/JSPgraphSchedule.PNG": "76ab70693b00b609ffc64062f22d6ae5",
"assets/assets/images/mmasDelta.PNG": "07ff3d04432b634570d33dabc28bc791",
"assets/assets/images/mmasOperator.PNG": "f26bb7c2aa0908658b5abd993192077b",
"assets/assets/images/mmasUpdate.PNG": "1bd46e99e744eb1957a704d1bc3ab72d",
"assets/assets/images/mountainProcessing.PNG": "91f36098a7545474a83475e5ae8fba2e",
"assets/assets/images/pheromoneDelta.PNG": "2e99eeb707c482388d007267b7f55d0f",
"assets/assets/images/pheromoneUpdate.PNG": "731cc9805d17adb6ba59ce73ac21d772",
"assets/assets/images/schedules.PNG": "6d351a8bfffaacdbc48e9e2cbb2e9c7e",
"assets/assets/images/tsp.PNG": "0b91988c8af57a98fe76523e888a0065",
"assets/FontManifest.json": "71a4a82de411f155107da3f8dac64ebd",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/NOTICES": "862e14793f843d5d2dfc630c963bb886",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_AMS-Regular.ttf": "657a5353a553777e270827bd1630e467",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Bold.ttf": "a9c8e437146ef63fcd6fae7cf65ca859",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Caligraphic-Regular.ttf": "7ec92adfa4fe03eb8e9bfb60813df1fa",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Bold.ttf": "46b41c4de7a936d099575185a94855c4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Fraktur-Regular.ttf": "dede6f2c7dad4402fa205644391b3a94",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Bold.ttf": "9eef86c1f9efa78ab93d41a0551948f7",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-BoldItalic.ttf": "e3c361ea8d1c215805439ce0941a1c8d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Italic.ttf": "ac3b1882325add4f148f05db8cafd401",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Main-Regular.ttf": "5a5766c715ee765aa1398997643f1589",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-BoldItalic.ttf": "946a26954ab7fbd7ea78df07795a6cbc",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Math-Italic.ttf": "a7732ecb5840a15be39e1eda377bc21d",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Bold.ttf": "ad0a28f28f736cf4c121bcb0e719b88a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Italic.ttf": "d89b80e7bdd57d238eeaa80ed9a1013a",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_SansSerif-Regular.ttf": "b5f967ed9e4933f1c3165a12fe3436df",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Script-Regular.ttf": "55d2dcd4778875a53ff09320a85a5296",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size1-Regular.ttf": "1e6a3368d660edc3a2fbbe72edfeaa85",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size2-Regular.ttf": "959972785387fe35f7d47dbfb0385bc4",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size3-Regular.ttf": "e87212c26bb86c21eb028aba2ac53ec3",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Size4-Regular.ttf": "85554307b465da7eb785fd3ce52ad282",
"assets/packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_Typewriter-Regular.ttf": "87f56927f1ba726ce0591955c8b3b42d",
"assets/packages/wakelock_web/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "24e57c236511b118c630d6fbc6452f82",
"/": "24e57c236511b118c630d6fbc6452f82",
"main.dart.js": "873ed1837f751223db98b4c806e1e52f",
"manifest.json": "8812366c49e8108a6d1ca9086f08701c",
"version.json": "21c8a6b863bf09b8e490aa511eda62c6"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
