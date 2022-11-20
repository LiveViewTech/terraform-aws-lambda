package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/retry"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

var (
	region    string
	parameter string
)

func main() {
	getCommandLineArgs()
	ctx, cancel := context.WithTimeout(context.TODO(), time.Duration(5000)*time.Millisecond)
	defer cancel()

	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(region), config.WithRetryer(func() aws.Retryer {
		return retry.AddWithMaxAttempts(aws.NopRetryer{}, 1)
	}))

	if err != nil {
		panic(err)
	}

	ssm_client := ssm.NewFromConfig(cfg, func(o *ssm.Options) {
		o.Credentials = aws.NewCredentialsCache(credentials.NewStaticCredentialsProvider(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), os.Getenv("AWS_SESSION_TOKEN")))
	})

	param, err := ssm_client.GetParameter(ctx, &ssm.GetParameterInput{
		Name:           aws.String(parameter),
		WithDecryption: aws.Bool(true),
	})

	if err != nil {
		panic(err)
	}

	value := *param.Parameter.Value
	fmt.Fprintln(os.Stdout, value)
}

func getCommandLineArgs() {
	flag.StringVar(&region, "region", "us-west-2", "AWS Region to use")
	flag.StringVar(&parameter, "parameter", "", "The name for the requested parameter")
	flag.Parse()
}
