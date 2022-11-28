import http from 'k6/http';
import { sleep } from 'k6';

export let options = {

    noConnectionReuse: false,
    stages: [
        { duration: '5m', target: 100}, //simulate ramp-up of traffic from 1 to 100 users over 5 minutes 
        { duration: '10m', target: 100}, // stay at 100 users for 10 minutes
        { duration: '5m', target: 0},  // ramp-down to 0 users
    ],
    thresholds: {
        http_req_duration: ['p(99)<150'], // 99% of requests must complete below 150ms
    }
}

const API_BASE_URL = 'http://192.168.0.77:8080/api/greet';

export default function () {
  http.batch([
      ['GET', `${API_BASE_URL}/steven`],
      ['GET', `${API_BASE_URL}/king`],
      ['GET', `${API_BASE_URL}/maria`],
  ])

  sleep(1);
}
