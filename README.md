# Simple Go Helloworld

Simple Go Helloworld is a web application written in Golang.

You could build and start the web application on your Docker host by running the following command:

```shell
make build-run
```

Finally, open your browser and navigate to http://localhost to see the application running.

![simple-go-helloworld](docs/simple-go-helloworld.png)

## Makefile targets

The repository provides a Makefile with the following targets to help you with the development and execution of the application:

- **build-binary**         Build application binary
- **build-docker**         Create a docker image to run the binary
- **build-run**            Build and run the application
- **clean**                Clean the project
- **help**                 Lists available targets
- **init**                 Initialize the project
- **modules**              Handle module dependencies
- **run**                  Run the application in a container
- **stop**                 Stop the application
- **test**                 Execute tests
- **update**               Update dependencies

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
