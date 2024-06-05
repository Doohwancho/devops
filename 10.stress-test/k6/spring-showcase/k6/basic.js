import http from 'k6/http';
import { sleep } from 'k6';

export default function () {
  http.get('http://192.168.0.77:8080/api/greet/Stephan');
  sleep(1);
}
