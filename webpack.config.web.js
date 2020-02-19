var HtmlWebpackPlugin = require("html-webpack-plugin")
var HtmlWebpackInlineSourcePlugin = require("html-webpack-inline-source-plugin")
var path = require("path")
var process = require("process")

module.exports = {
  target: "web",
  entry: "./index-web.js",
  mode: process.env.NODE_ENV ? process.env.NODE_ENV : "development",
  output: {
    path: path.resolve(__dirname, "./worker"),
    filename: "web.js"
  },
  optimization: {
		// We no not want to minimize our code.
		minimize: process.env.NODE_ENV == "production"
  },
  resolve: {
    extensions: ['.js', '.coffee']
  },
  plugins: [
    new HtmlWebpackPlugin({
      inlineSource: '.(js|css)$', // embed all javascript and css inline
      title: 'Angry.Im Pastebin',
      meta: {
        viewport: 'width=device-width, initial-scale=1, shrink-to-fit=no'
      }
    }),
    new HtmlWebpackInlineSourcePlugin()
  ],
  module: {
    rules: [
      {
        test: /\.scss$/,
        use: [ 'style-loader', 'css-loader', 'sass-loader' ]
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