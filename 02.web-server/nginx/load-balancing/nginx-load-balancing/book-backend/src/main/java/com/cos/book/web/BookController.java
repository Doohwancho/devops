package com.cos.book.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.cos.book.domain.Book;
import com.cos.book.service.BookService;

import lombok.RequiredArgsConstructor;

//@RequestMapping(value = "/api")
@RequiredArgsConstructor
@RestController
public class BookController {

	Logger logger = LoggerFactory.getLogger(BookController.class);

	private final BookService bookService;

//	@CrossOrigin
//	@GetMapping({ "", "/" })
//	public String hello() {
//		return "<h1>Hello</h1>";
//	}

	@CrossOrigin
	@PostMapping("/book")
	public ResponseEntity<?> save(@RequestBody Book book) {
		return new ResponseEntity<>(bookService.저장하기(book), HttpStatus.CREATED); // 200
	}

	@CrossOrigin
	@GetMapping("/book")
	public ResponseEntity<?> findAll() {
		return new ResponseEntity<>(bookService.모두가져오기(), HttpStatus.OK); // 200
	}

	@CrossOrigin
	@GetMapping("/book/{id}")
	public ResponseEntity<?> findById(@PathVariable Long id) {
		return new ResponseEntity<>(bookService.한건가져오기(id), HttpStatus.OK); // 200
	}

	@CrossOrigin
	@PutMapping("/book/{id}")
	public ResponseEntity<?> update(@PathVariable Long id, @RequestBody Book book) {
		return new ResponseEntity<>(bookService.수정하기(id, book), HttpStatus.OK); // 200
	}

	@CrossOrigin
	@DeleteMapping("/book/{id}")
	public ResponseEntity<?> deleteById(@PathVariable Long id) {
		return new ResponseEntity<>(bookService.삭제하기(id), HttpStatus.OK); // 200
	}
}
