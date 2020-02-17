var HtmlWebpackPlugin = require("html-webpack-plugin")
var HtmlWebpackInlineSourcePlugin = require("html-webpack-inline-source-plugin")
var path = require("path")

module.exports = {
  target: "web",
  entry: "./index-web.js",
  mode: "development",
  output: {
    path: path.resolve(__dirname, "./worker"),
    filename: "web.js"
  },
  optimization: {
		// We no not want to minimize our code.
		minimize: false
  },
  resolve: {
    extensions: ['.js', '.coffee']
  },
  plugins: [
    new HtmlWebpackPlugin({
      inlineSource: '.(js|css)$', // embed all javascript and css inline
      title: 'Angry.Im Pastebin'
    }),
    new HtmlWebpackInlineSourcePlugin()
  ],
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: [ 'url-loader' ]
      },
      {
        test: /\.coffee$/,
        use: [ 'babel-loader', 'coffee-loader' ]
      },
      {
        type: 'javascript/auto',
        test: /\.json$/,
        use: [ 'json-loader' ]
      }
    ]
  }
}