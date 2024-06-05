import React, { useEffect, useState } from 'react';
import BookItem from '../../components/BookItem';

const Home = () => {
  const [books, setBooks] = useState([]);

  // 함수 실행시 최초 한번 실행되는 것 + 상태값이 변경될때마다 실행
  useEffect(() => {
    // fetch('http://127.0.0.1:80/api/book') //error! localhost로 바꿔줘야 nginx에게 보내짐
    fetch('http://localhost:80/api/book')
      .then((res) => res.json())
      .then((res) => {
        setBooks(res);
      }); // 비동기 함수

      /*
        Q. localhost가 본인을 가르킨다면, http://localhost:80/으로 보낸건 frontend-a 컨테이너로 보내져야지, 왜 nginx 컨테이너로 보내짐?

        guess) localhost는 자신이 아니라 gateway로 보내진거라서 그런거 아냐?

        음.. 까볼까?

        docker network ls
          - docker inspect docker network bridge 
            gateway: 172.17.0.1  
            subnet: 172.17.0.0/16
          
            - docker inspect frontend_network
              gateway: 172.22.0.1
              subnet: 172.22.0.0/16

              - 1. nginx : 172.22.0.3/16
              - 2. frontend-a : 172.22.0.2/16

            - docker inspect backend_network
              gateway: 172.23.0.1
              subnet: 172.23.0.0/16

              - 3. backend-a : 172.23.0.3/16
              - 4. database : 172.23.0.2/16

        frontend-a에서 localhost를 하면, 본인 대역대인 172.22번 대역대에 172.22.0.0 을 가르키는데,
        이 때, default.conf로 localhost를 listening하던 nginx가 172.22.0.0:80 을 가로채서 redirect한 듯?

        127.0.0.1:80이 에러나는 이유는
        127.0.0.1은 특수 ip라서 랜카드까지 안가고 바로 172.23.0.2 본인으로 redirect해주기 때문.
              
      */

  }, []);

  return (
    <div>
      {books.map((book) => (
        <BookItem key={book.id} book={book} />
      ))}
    </div>
  );
};

export default Home;
