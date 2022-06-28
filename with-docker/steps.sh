git clone --recurse-submodules https://$GITHUB_TOKEN@github.com/$GITHUB_ORGANIZATION/cs-cart-docker.git
cd cs-cart-docker
cp .env.example .env
docker-compose up -d