#For Programming language Go
export GOARCH="386"
export GOBIN=""
export GOCHAR="8"
export GOEXE=""
export GOHOSTARCH="386"
export GOHOSTOS="darwin"
export GOOS="darwin"
export GOPATH="go/my_projects"
export GORACE=""
export GOROOT="/usr/local/go"
export GOTOOLDIR="/usr/local/go/pkg/tool/darwin_386"
export CC="gcc"
export GOGCCFLAGS="-g -O2 -fPIC -m32 -pthread -fno-common"
export CGO_ENABLED="1"

export PATH=/bin:/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$PATH
#export PATH=/usr/local/php5/bin:$PATH
export EDITOR='subl -w'


[ -n "$PS1" ] && source ~/.bash_profile
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
#PATH=$PATH:$HOME/.rvm/bin:GOROOT/bin
#./z.sh
source kvm.sh

