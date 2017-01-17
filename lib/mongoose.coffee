mongoose = require 'mongoose'
mongoose.Promise = global.Promise
mongoose.connect(process.env.MONGODB_URI)
mongoose.model 'Checkstyle', {signal: String, file: String, lineno: Number, detail: String, type: String}

module.exports = mongoose
