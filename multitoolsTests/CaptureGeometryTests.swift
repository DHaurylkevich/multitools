import CoreGraphics
import Testing
@testable import multitools

struct CaptureGeometryTests {

    private let screenFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)

    @Test func selectionIsConvertedToTopLeftCoordinates() {
        let region = CaptureGeometry.region(
            for: CGRect(x: 100, y: 100, width: 200, height: 100),
            screenFrame: screenFrame,
            pixelScale: 1
        )

        #expect(region == CaptureRegion(
            sourceRect: CGRect(x: 100, y: 880, width: 200, height: 100),
            pixelWidth: 200,
            pixelHeight: 100
        ))
    }

    @Test func pixelSizeFollowsDisplayScale() {
        let region = CaptureGeometry.region(
            for: CGRect(x: 0, y: 0, width: 300, height: 150),
            screenFrame: screenFrame,
            pixelScale: 2
        )

        #expect(region?.pixelWidth == 600)
        #expect(region?.pixelHeight == 300)
    }

    @Test func selectionIsClippedToScreenFrame() {
        let region = CaptureGeometry.region(
            for: CGRect(x: 1800, y: 1000, width: 500, height: 500),
            screenFrame: screenFrame,
            pixelScale: 1
        )

        #expect(region?.sourceRect == CGRect(x: 1800, y: 0, width: 120, height: 80))
    }

    @Test func selectionOutsideScreenHasNoRegion() {
        let region = CaptureGeometry.region(
            for: CGRect(x: 2000, y: 2000, width: 100, height: 100),
            screenFrame: screenFrame,
            pixelScale: 1
        )

        #expect(region == nil)
    }

    @Test func zeroWidthScreenFallsBackToUnitScale() {
        #expect(CaptureGeometry.pixelScale(screenWidth: 0, displayPixelWidth: 2880) == 1)
    }

    @Test func outputSizeIsCappedOnLongestSide() {
        let size = CaptureGeometry.outputSize(
            pixelWidth: 3840,
            pixelHeight: 2160,
            maxDimension: 2000
        )

        #expect(size == CaptureSize(width: 2000, height: 1125))
    }

    @Test func smallCaptureIsNotUpscaled() {
        let size = CaptureGeometry.outputSize(
            pixelWidth: 800,
            pixelHeight: 400,
            maxDimension: 2000
        )

        #expect(size == CaptureSize(width: 800, height: 400))
    }
}
