package webserver

import "testing"

func TestWebserver_AddHandler(t *testing.T) {
	type fields struct {
		Port     int
		Handlers map[string]Handler
	}
	type args struct {
		uri     string
		handler Handler
	}
	tests := []struct {
		name   string
		fields fields
		args   args
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := &Webserver{
				Port:     tt.fields.Port,
				Handlers: tt.fields.Handlers,
			}
			w.AddHandler(tt.args.uri, tt.args.handler)
		})
	}
}

func TestWebserver_LoadHandlers(t *testing.T) {
	type fields struct {
		Port     int
		Handlers map[string]Handler
	}
	tests := []struct {
		name   string
		fields fields
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := &Webserver{
				Port:     tt.fields.Port,
				Handlers: tt.fields.Handlers,
			}
			w.LoadHandlers()
		})
	}
}

func TestWebserver_Start(t *testing.T) {
	type fields struct {
		Port     int
		Handlers map[string]Handler
	}
	tests := []struct {
		name   string
		fields fields
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			w := &Webserver{
				Port:     tt.fields.Port,
				Handlers: tt.fields.Handlers,
			}
			w.Start()
		})
	}
}
