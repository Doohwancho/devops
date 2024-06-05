import http from 'k6/http';
import { sleep } from 'k6';

export let options = {

    noConnectionReuse: false,
    stages: [
        { duration: '2m', target: 400}, // ramp up to users
        { duration: '3h56m', target: 100}, //stay at 400 for ~4 hours
        { duration: '2m', target: 0}, //scale down
    ]
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
