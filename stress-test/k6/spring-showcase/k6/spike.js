import http from 'k6/http';
import { sleep } from 'k6';

export let options = {

    noConnectionReuse: false,
    stages: [
        { duration: '10s', target: 100}, //below normal load
        { duration: '1m', target: 100}, //서버 예열, 잠시 있음 
        { duration: '10s', target: 1400}, //spike to 1400 users
        { duration: '3m', target: 1400}, //잠시 있음
        { duration: '10s', target: 100}, //scale down, recovery stage 
        { duration: '3m', target: 100}, 
        { duration: '10s', target: 0},
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
