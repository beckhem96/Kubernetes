package com.example.kube.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Date;

@Controller
public class TestController {

    @GetMapping("/test")
    public String test(Model model) {
        model.addAttribute("currentTime", new Date());
        model.addAttribute("message", "Hello from Kubernetes!");
        return "test";
    }
}
