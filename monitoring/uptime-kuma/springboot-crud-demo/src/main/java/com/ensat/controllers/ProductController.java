package com.ensat.controllers;

import com.ensat.entities.Product;
import com.ensat.services.ProductService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;


/**
 * Product controller.
 */
@Controller("/products")
public class ProductController {
     @Autowired
     private ProductService productService;

     // initialize logger
     private static final Logger log = LoggerFactory.getLogger(ProductController.class);

    @RequestMapping(method = RequestMethod.GET, path = "/products")
    public String list(Model model) {
//       log.info(String.valueOf(model));
        model.addAttribute("products", productService.listAllProducts());
        System.out.println("Returning products:");
        return "products";
    }

//    @RequestMapping(method = RequestMethod.GET, path = "/product/{id}")
//    public String showProduct(@PathVariable Integer id, Model model) {
//        model.addAttribute("product", productService.getProductById(id));
//        return "productshow";
//    }

    // Afficher le formulaire de modification du Product
    @RequestMapping(method = RequestMethod.GET, path = "/product/edit/{id}")
    public String edit(@PathVariable Integer id, Model model) {
        model.addAttribute("product", productService.getProductById(id));
        return "productform";
    }

    @RequestMapping(method = RequestMethod.GET, path = "/product/new")
    public String newProduct(Model model) {
        model.addAttribute("product", new Product());
        return "productform";
    }

    @RequestMapping(method = RequestMethod.POST, path = "/product")
    public String saveProduct(@RequestBody Product product) { //@RequestBody를 붙이면 api call 가능한데, 웹사이트에서 수동으로 post는 못함. 빼면 api call은 안되는데, website 상에서 수동으로 post는 가능함.
//        log.info(product.getName());
        productService.saveProduct(product);
        return "redirect:/products";
    }

    @RequestMapping(method = RequestMethod.GET, path = "/product/{id}")
    public String delete(@PathVariable Integer id) {
        productService.deleteProduct(id);
        return "redirect:/products";
    }

}
