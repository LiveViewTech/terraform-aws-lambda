package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
)

type (
	response struct {
		Parameter struct {
			Value string `json:"Value"`
		} `json:"Parameter"`
	}
)

func main() {
	args := os.Args[1:]
	value := args[0]
	token := args[1]
	request, err := http.NewRequest("GET", "http://localhost:2773/systemsmanager/parameters/get", nil)
	if err != nil {
		panic(err)
	}
	request.Header.Set("X-Aws-Parameters-Secrets-Token", token)
	q := request.URL.Query()
	q.Add("name", value)
	q.Add("withDecryption", "true")
	request.URL.RawQuery = q.Encode()
	client := &http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		panic(err)
	}
	defer func() {
		if err := resp.Body.Close(); err != nil {
			panic(err)
		}
	}()

	s := &response{}
	if err := json.NewDecoder(resp.Body).Decode(s); err != nil {
		panic(value)
	}
	fmt.Fprintln(os.Stdout, s.Parameter.Value)
}
