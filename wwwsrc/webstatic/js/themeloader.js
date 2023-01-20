window.addEventListener('load', function () {
    const configMap = [
        // { id: 'debug', start: 1212, end: 1213, js: true, css: true }, // For debugging only
        { id: 'chunjie', start: 0117, end: 0221, js: true, css: true },
        { id: null, start: 0101, end: 1231 } // Last resort, no theme
    ];
    const params = {};
    if (location.search) {
        location.search.slice(1).split('&').array.forEach(function (kv) {
            const arr = kv.split('=');
            params[arr[0]] = arr[1];
        });
    }
    let themeId = params.theme;
    let datecode = parseInt(params.datecode);
    if (!themeId) {
        if (!datecode) {
            datecode = parseInt((new Date()).toISOString().slice(5, 10).replace('-', ''));
        };
        themeId = configMap.map(function (x) {
            if (x.start <= datecode && datecode <= x.end) {
                return x.id;
            };
        })[0];
    };
    const theme = configMap.filter(x => x.id === themeId)[0];
    if (!theme) {
        console.log('No theme for today');
        return 0;
    }
    if (theme.js) {
        const jsTag = document.createElement('script');
        jsTag.setAttribute('src', `/webstatic/themes/${theme.id}.js`);
        document.head.appendChild(jsTag);
    };
    if (theme.css) {
        const cssTag = document.createElement('link');
        cssTag.setAttribute('rel', 'stylesheet');
        cssTag.setAttribute('type', 'text/css');
        cssTag.setAttribute('href', `/webstatic/themes/${theme.id}.css`);
        document.head.appendChild(cssTag);
    };

    const startJob = function (func, argv, interval, life) {
        const fn = func.name;
        const limit = life * 1000 / interval;       // 20s life at 100ms interval means 20*1000/100=200 recursions
        const _jobLabmda = function (fn, func, argv, interval, recur, limit) {
            if (recur >= limit) { console.log(`Job ${fn} exited after ${recur} recursions.`); return 0; };
            func.apply(null, argv);
            setTimeout(function () {
                _jobLabmda(fn, func, argv, interval, recur + 1, limit);
            }, interval);
        };
        _jobLabmda(fn, func, argv, interval, 0, limit);
    };
    if (window.resizeTopAvatar) { startJob(resizeTopAvatar, [], 50, 10) };
});
