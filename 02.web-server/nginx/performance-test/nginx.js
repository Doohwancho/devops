import http from 'k6/http';
import { sleep } from 'k6';

export default function () {
  http.get('http://192.168.219.101:8081');
  sleep(1);
}

