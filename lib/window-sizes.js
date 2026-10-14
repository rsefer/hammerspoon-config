const gridWidth = 100
const gridHeight = 60
const thirdCenter = gridWidth * 2 / 3
const thirdLeft = gridWidth - thirdCenter
const halfHeightTop = gridHeight * 0.65
const halfHeightBottom = gridHeight - halfHeightTop

const sizes = {
	full: [0, 0, gridWidth, gridHeight],
	center: [gridWidth / 5, gridHeight / 5, gridWidth * 3 / 5, gridHeight * 3 / 5],
	halves: {
		left: [0, 0, gridWidth / 2, gridHeight],
		right: [gridWidth / 2, 0, gridWidth / 2, gridHeight],
		leftTop: [0, 0, gridWidth / 2, gridHeight]
	},
	thirds: {
		left: [0, 0, thirdLeft, gridHeight],
		center: [thirdLeft, 0, thirdLeft, gridHeight],
		right: [thirdCenter, 0, gridWidth - thirdCenter, gridHeight],
		leftTop: [0, 0, gridWidth - thirdCenter, halfHeightTop],
		leftBottom: [0, halfHeightTop, gridWidth - thirdCenter, halfHeightBottom],
		rightTop: [thirdCenter, 0, gridWidth - thirdCenter, halfHeightTop],
		rightBottom: [thirdCenter, halfHeightTop, gridWidth - thirdCenter, halfHeightBottom],
		left2: [0, 0, thirdCenter, gridHeight],
		right2: [gridWidth - thirdCenter, 0, thirdCenter, gridHeight]
	},
	quadrants: {
		one: [gridWidth / 2, 0, gridWidth / 2, gridHeight / 2],
		two: [0, 0, gridWidth / 2, gridHeight / 2],
		three: [0, gridHeight / 2, gridWidth / 2, gridHeight / 2],
		four: [gridWidth / 2, gridHeight / 2, gridWidth / 2, gridHeight / 2]
	}
}

module.exports = { sizes, gridWidth, gridHeight }
