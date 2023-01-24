window.addEventListener('load', function () {
    const js = true;
    const css = true;
    const configMap = [
        // { id: 'debug', start: 1212, end: 1213, js: true, css: true }, // For debugging only
        { id: 'chunjie', start: 0117, end: 0221, js, css },
        { id: 'apple', start: 0331, end: 0402, js, css },
        { id: '0529', start: 0527, end: 0531, js, css },
        { id: 'birthday', start: 0913, end: 0916, js },
        { id: 'null', start: 0101, end: 1231 } // Last resort, no theme
    ];
    const params = {};
    if (location.search) {
        location.search.slice(1).split('&').forEach(function (kv) {
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
    if (themeId === 'null' || configMap.filter(x => x.id === themeId).length === 0) {
        console.log('No theme for today');
        return 0;
    };
    const theme = configMap.filter(x => x.id === themeId)[0];
    if (theme.js) {
        const jsTag = document.createElement('script');
        jsTag.setAttribute('async', 'true');
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


    const startJob = function (fn, func, argv, interval, life) {
        const limit = Math.ceil(life * 1000 / interval);       // 20s life at 100ms interval means 20*1000/100=200 recursions
        const _jobLabmda = function (fn, func, argv, interval, recur, limit) {
            if (recur >= limit) { console.log(`Job ${fn} exited after ${recur} recursions.`); return 0; };
            func.apply(null, argv);
            window.setTimeout(function () {
                _jobLabmda(fn, func, argv, interval, recur + 1, limit);
            }, interval);
        };
        console.log(`themeloader.js: Starting job for ${fn}`);
        _jobLabmda(fn, func, argv, interval, 0, limit);
    };
    if (window.resizeTopAvatar) {
        startJob('resizeTopAvatar', resizeTopAvatar, [], 100, 30);
    };

    // Other custom jobs here...
    window.setTimeout(function () {
        startJob('pinMySize', function () {
            document.querySelectorAll('.pinMySize').forEach(function (node) {
                node.classList.remove('pinMySize');
                const h = node.offsetHeight;
                const w = node.offsetWidth;
                node.style.height = h + 'px';
                node.style.width = w + 'px';
            });
        }, [], 250, 20);
        if (params.theme) {
            startJob('setHrefThemeId', function () {
                document.querySelectorAll('a[href]').forEach(function (anchor) {
                    const h = anchor.getAttribute('href');
                    // ?theme=apple
                    if (h.match(/^(\.?\.?\/|\w)/) && h.match(/\/$/) && !h.match(/(\/\/|\?|\#)/)) {
                        // Absolute/relative path
                        // Ends with '/'
                        // Contains no '?' or '#' or '//'
                        anchor.setAttribute('href', h + '?theme=' + themeId);
                    };
                });
            }, [], 500, 5);
        }
        if (location.hash === '#availWidth') {
            alert(window.screen.availWidth);
        };
    }, 500);
}, { capture: true });
