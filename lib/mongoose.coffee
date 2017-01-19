mongoose = require 'mongoose'
mongoose.Promise = global.Promise
mongoose.connect(process.env.MONGODB_URI)
mongoose.model 'Checkstyle', {signal: String, file: String, lineno: Number, sub_lineno: Number, detail: String, type: String}
mongoose.model 'FalsePositiveWarning', {commit: String, file: String, lineno: Number, detail: String}

module.exports = mongoose
