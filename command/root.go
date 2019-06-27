package command

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var rootCmd = &cobra.Command{
	Use:   "simple-go-helloworld",
	Short: "simple-go-helloworld",
	Long:  `simple-go-helloworld`,
	Run: func(cmd *cobra.Command, args []string) {
		cmd.HelpFunc()(cmd, args)
	},
}

func init() {
	viper.AutomaticEnv()
	viper.SetEnvPrefix("simple_go_helloworld") // will be uppercased automatically
	viper.BindEnv("port")
}

// Execute command method
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
