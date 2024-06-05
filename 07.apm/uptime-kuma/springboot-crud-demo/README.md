
# what
부하테스트시 데이터베이스 CRUD용 프로젝트
localhost:8080/products

# how
1. 전체 글 보기
   1. `GET localhost:8080/products`
2. 글 등록
```
POST localhost:8080/product
{
    "productId": 1,
    "name": "test",
    "price": 1000
}
```
3. 글 삭제
   1. `GET localhost:8080/product/${product.id}`



# 주의 
ProductController에 
public String saveProduct(@RequestBody Product product) {} 에서,

@RequestBody를 붙이면 api call 가능한데, 웹사이트에서 수동으로 post는 못함.\
@RequestBody를 빼면 api call은 안되는데, website 상에서 수동으로 post는 가능함.