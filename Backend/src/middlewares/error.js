export const errorHandler = (err, req, res, next) => {
  console.log("Error middleware triggered");
  console.error("ERROR:", err);
  // Check if headers are already sent
  if(res.headersSent) {
    return next(err);
  }
 
  // Send error response
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });

  // Call next middleware (if any)
  next();
};