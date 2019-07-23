package webserver

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type Handler func(w http.ResponseWriter, r *http.Request)

type Webserver struct {
	server   *http.Server
	Handlers map[string]Handler
}

func NewWebserver(l string) *Webserver {
	router := http.NewServeMux()

	server := &http.Server{
		Addr:         l,
		Handler:      router,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  15 * time.Second,
	}

	return &Webserver{
		server:   server,
		Handlers: map[string]Handler{},
	}
}

func (w *Webserver) AddHandler(uri string, handler Handler) {
	if w.Handlers == nil {
		w.Handlers = map[string]Handler{}
	}

	w.Handlers[uri] = handler
}

func (w *Webserver) LoadHandlers() {
	mux := w.server.Handler.(*http.ServeMux)

	for uri, handler := range w.Handlers {
		log.Printf("Registering new handler on %v", uri)
		mux.HandleFunc(uri, handler)
	}
}

func (w *Webserver) Start() {

	done := make(chan bool)
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, os.Interrupt, os.Kill, syscall.SIGTERM)

	go func() {
		signalType := <-ch
		fmt.Println("Exit command received. Exiting...")
		fmt.Println("Received signal type : ", signalType)

		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()

		err := w.server.Shutdown(ctx)
		if err != nil {
			fmt.Printf("Could not gracefully shutdown the server: %v\n", err)
		}

		signal.Stop(ch)

		close(done)
	}()

	w.LoadHandlers()
	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
	<-done
}
