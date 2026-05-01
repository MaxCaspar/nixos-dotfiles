#!/usr/bin/env bash
# Fetches current weather for Bünbach, Bavaria from wttr.in and outputs JSON.
curl -sf "wttr.in/Bamberg,Bavaria?format=j1" 2>/dev/null | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)['current_condition'][0]
    print(json.dumps({
        'temp':     d['temp_C'],
        'feels':    d['FeelsLikeC'],
        'desc':     d['weatherDesc'][0]['value'],
        'humidity': d['humidity'],
        'wind':     d['windspeedKmph'],
    }))
except Exception:
    print('{\"temp\":\"--\",\"feels\":\"--\",\"desc\":\"unavailable\",\"humidity\":\"--\",\"wind\":\"--\"}')
"
