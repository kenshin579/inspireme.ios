.PHONY: help generate build build-sim open archive tag clean

# ========================================
# 도움말
# ========================================

help:
	@echo "InspireMe iOS 개발 명령어"
	@echo ""
	@echo "개발:"
	@echo "  generate    XcodeGen으로 .xcodeproj 생성"
	@echo "  build       iOS 디바이스용 빌드 (서명 없음)"
	@echo "  build-sim   iOS 시뮬레이터용 빌드"
	@echo "  open        Xcode에서 프로젝트 열기"
	@echo ""
	@echo "릴리스:"
	@echo "  archive     Release 아카이브 생성"
	@echo "  make tag patch|minor|major   버전 태그 + GitHub Release 생성"
	@echo "  clean       빌드 결과물 삭제"

# ========================================
# 개발
# ========================================

generate:
	@xcodegen generate

build: generate
	@xcodebuild build \
		-project InspireMe.xcodeproj \
		-scheme InspireMe \
		-sdk iphoneos \
		CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=""

build-sim: generate
	@xcodebuild build \
		-project InspireMe.xcodeproj \
		-scheme InspireMe \
		-destination 'platform=iOS Simulator,name=iPhone 17 Pro'

open: generate
	@open InspireMe.xcodeproj

# ========================================
# 릴리스
# ========================================

VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "1.0.0")
BUILD_NUMBER := $(shell git rev-list --count HEAD)

archive: generate
	@echo "Archiving InspireMe v$(VERSION) (build $(BUILD_NUMBER))..."
	@xcodebuild archive \
		-project InspireMe.xcodeproj \
		-scheme InspireMe \
		-archivePath build/InspireMe.xcarchive \
		-destination 'generic/platform=iOS' \
		-allowProvisioningUpdates \
		MARKETING_VERSION=$(VERSION) \
		CURRENT_PROJECT_VERSION=$(BUILD_NUMBER)

tag:
	@./scripts/release.sh $(filter-out $@,$(MAKECMDGOALS))

clean:
	@rm -rf build/ DerivedData/
	@echo "Build artifacts cleaned."

# 인자를 타겟으로 인식하지 않도록 처리
%:
	@:
