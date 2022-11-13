package config

import (
	"os"
	"path/filepath"
)

var (
	CAFile          = configFile("ca.pem")
	CA2File         = configFile("ca2.pem")
	ServerCertFile  = configFile("server.pem")
	ServerKeyFile   = configFile("server-key.pem")
	ClientCertFile  = configFile("client.pem")
	ClientKeyFile   = configFile("client-key.pem")
	Client2CertFile = configFile("client2.pem")
	Client2KeyFile  = configFile("client2-key.pem")
)

func configFile(filename string) string {
	if dir := os.Getenv("CONFIG_DIR"); dir != "" {
		return filepath.Join(dir, filename)
	}
	homeDir, err := os.UserHomeDir()
	if err != nil {
		panic(err)
	}
	return filepath.Join(homeDir, ".proglog", filename)
}
