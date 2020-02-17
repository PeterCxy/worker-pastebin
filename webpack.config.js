module.exports = {
  target: "webworker",
  entry: "./index.js",
  mode: "production",
  optimization: {
		// We no not want to minimize our code.
		minimize: false
  },
  resolve: {
    extensions: ['.js', '.coffee']
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        type: 'javascript/auto',
        test: /\.json$/,
        use: [ 'json-loader' ]
      },
      {
        test: /\.html$/,
        use: [ 'raw-loader' ]
      }
    ]
  }
}