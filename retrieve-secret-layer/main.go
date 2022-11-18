package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/retry"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

type (
	response struct {
		Parameter struct {
			Value string `json:"Value"`
		} `json:"Parameter"`
	}
)

var (
	region  string
	secret  string
	roleArn string
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
	ssm_client := secretsmanager.NewFromConfig(cfg, func(o *secretsmanager.Options) {
		o.Credentials = aws.NewCredentialsCache(credentials.NewStaticCredentialsProvider(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), os.Getenv("AWS_SESSION_TOKEN")))
	})

	result, err := ssm_client.GetSecretValue(ctx, &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secret),
	},
	)
	if err != nil {
		fmt.Fprintln(os.Stdout, secret)
		panic(err)
	}

	data := map[string]interface{}{}
	if err := json.Unmarshal([]byte(*result.SecretString), &data); err != nil {
		panic(err)
	}

	for _, value := range data {
		fmt.Fprintln(os.Stdout, fmt.Sprintf("%s", value))
	}

}

func getCommandLineArgs() {
	flag.StringVar(&region, "region", "us-west-2", "AWS Region to use")
	flag.StringVar(&secret, "secret", "", "The ARN for the requested parameter")
	flag.StringVar(&roleArn, "role", "", "The ARN for the role to assume")
	flag.Parse()
}
