import http from 'k6/http';
import { sleep } from 'k6';

export let options = {

    noConnectionReuse: false,
    stages: [
        { duration: '2m', target: 100}, //below normal load
        { duration: '5m', target: 100}, 
        { duration: '2m', target: 200}, //normal load
        { duration: '5m', target: 200}, 
        { duration: '2m', target: 300}, //around the breaking point
        { duration: '5m', target: 300}, 
        { duration: '2m', target: 400}, //beyong the breaking point
        { duration: '5m', target: 400}, 
        { duration: '10m', target: 0}, //scale down. recovery stage
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
