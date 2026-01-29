#!/bin/bash

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 사용법 출력
usage() {
    echo "Usage: $0 [dev|prod] [apply|delete|dry-run]"
    echo ""
    echo "Environments:"
    echo "  dev     - Development environment"
    echo "  prod    - Production environment"
    echo ""
    echo "Actions:"
    echo "  apply    - Apply Kubernetes resources"
    echo "  delete   - Delete Kubernetes resources"
    echo "  dry-run  - Preview changes without applying"
    echo ""
    echo "Examples:"
    echo "  $0 dev apply      # Deploy to development"
    echo "  $0 prod dry-run   # Preview production deployment"
    echo "  $0 dev delete     # Remove development deployment"
    exit 1
}

# 인자 확인
if [ $# -lt 2 ]; then
    usage
fi

ENV=$1
ACTION=$2

# 환경 검증
if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
    echo -e "${RED}Error: Invalid environment '$ENV'. Use 'dev' or 'prod'.${NC}"
    usage
fi

# 액션 검증
if [ "$ACTION" != "apply" ] && [ "$ACTION" != "delete" ] && [ "$ACTION" != "dry-run" ]; then
    echo -e "${RED}Error: Invalid action '$ACTION'. Use 'apply', 'delete', or 'dry-run'.${NC}"
    usage
fi

OVERLAY_PATH="k8s/overlays/$ENV"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Environment: $ENV${NC}"
echo -e "${YELLOW}Action: $ACTION${NC}"
echo -e "${YELLOW}Path: $OVERLAY_PATH${NC}"
echo -e "${YELLOW}========================================${NC}"

# kubectl 확인
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# kustomize 존재 확인
if [ ! -d "$OVERLAY_PATH" ]; then
    echo -e "${RED}Error: Overlay path '$OVERLAY_PATH' does not exist${NC}"
    exit 1
fi

case $ACTION in
    apply)
        echo -e "${GREEN}Applying $ENV environment...${NC}"
        kubectl apply -k "$OVERLAY_PATH"
        echo -e "${GREEN}Deployment completed!${NC}"
        ;;
    delete)
        echo -e "${YELLOW}Deleting $ENV environment...${NC}"
        read -p "Are you sure you want to delete? (y/N): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            kubectl delete -k "$OVERLAY_PATH"
            echo -e "${GREEN}Deletion completed!${NC}"
        else
            echo -e "${YELLOW}Deletion cancelled.${NC}"
        fi
        ;;
    dry-run)
        echo -e "${GREEN}Dry-run preview for $ENV environment:${NC}"
        kubectl apply -k "$OVERLAY_PATH" --dry-run=client -o yaml
        ;;
esac

echo -e "${GREEN}Done!${NC}"
