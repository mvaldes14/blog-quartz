---
title: Golang Interafaces are easy
date: 12/18/2024
draft: true
tags:
- coding
- golang
---

Recently been doing a lot of Golang for my twitch bot (I stream btw, rarely but I do). So while setting up the web-server I wanted to customize some of the functionality so each request checks the headers and respond differently based on said headers. So i went down the rabbit hole into Middleware and based on a book I'm reading called "Let's Go" by Alex Edwards you can pretty much "overload" the default methods as long as it satisfies the interface.
### So wtf is an interface?
It's basically a definition of something that contains functions/variables/parameters and those must exist and return/do what the interface demands. 
- The definition is: A contract that has to be followed.
- For those of us who are 5: Either it does what the interface says or it won't work and it doesn't care how you do it.

So let's check a very minimal example of that same task I'm working on. Here's the breakdown of the flow.

1. A request is received on an endpoint
2. Request is passed to a handler
3. Check the request headers and do something based on that
4. Return response to user

So what is the interface for an http handler?
```go
type Handler interface {
	ServeHTTP(ResponseWriter, *Request)
}
```

We will require a function that satisfies that interface, aka a function that accepts a Writer and a Request,  those 2 are interfaces on their own but we won't go into them. 

```go
// 
type customHandler struct {
	HeaderCheck string	
}

func (c *customHandler) ServeHTTP(w http.ResponseWritter, r *http.Request) {
	if _, ok := r.Header[c.HeaderCheck]; ok {
		w.Write([]byte("Found your header value here"))
	}
}

// The main declaration for our webserver
func main(){
	mux := http.NewServerMux()
	custom := customHandler{HeatherCheck: "subscription"}
	mux.Handle("/", custom)
	http.ListenAndServe(":3000", mux)
}
```

So what did we do?
- A struct was created with a simple string field that will be used to validate
- A function was done on that struct that __satisfies__ the interface
- The handle function is happy with our handler as it has a method `ServeHTTP` which is the interface of type `Handler`
- Web-server works as intended, when a header that has a key value "subscription" comes up our server will respond to the user

```bash
➜  curl localhost:3000 -H 'subscription: true'
Found your header value here
```

Now that's pretty much how interfaces work. They allow you to grab existing behavior to let you add more functionality to it.
In your go journey you will find them pretty often and they are very common in some of the regular operations like opening files/buffers, reading data from a location or working with web servers like we saw above.

## Conclusion like I'm 5
- It's like making a piece of a puzzle match a missing slot
- Interfaces are ways to let you customize how things work as long as you follow the basic rules.
- You will use them without knowing as they are cooked within everyday functions and libraries
- Each interface you do must be a function of a something, most of the times it will be a struct which can be empty or have 0 fields as long as it can do the function the interface dictates

Hope this helps you as interfaces was the one concept that completely made no sense in my head until I had to actually use one to change the behavior of something.

Adios 👋