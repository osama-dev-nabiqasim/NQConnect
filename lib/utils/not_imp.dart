
// const express = require("express");
// const router = express.Router();
// const { getPool } = require("../config/db");
// const { authenticateToken } = require("./auth"); // Import middleware

// // Apply auth to all routes (except GET if public)
// router.use(authenticateToken);

// // GET all suggestions (public, but with auth for user-specific)
// router.get("/", async (req, res) => {
//   try {
//     const pool = await getPool();
//     const result = await pool.request().query("SELECT * FROM suggestions ORDER BY created_at DESC");

//     res.json({
//       success: true,
//       data: result.recordset,
//     });
//   } catch (err) {
//     console.error("Get Suggestions Error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch suggestions",
//       error: err.message,
//     });
//   }
// });

// // POST new suggestion (authenticated)
// router.post("/", async (req, res) => {
//   const {
//     title,
//     description,
//     category,
//     employee_id,
//     employee_name,
//     department,
//   } = req.body;

//   if (!title || !description || !category || !employee_id || !employee_name || !department) {
//     return res.status(400).json({
//       success: false,
//       message: "All fields are required",
//     });
//   }

//   // Verify user from JWT
//   if (req.user.employee_id !== employee_id) {
//     return res.status(403).json({
//       success: false,
//       message: "Unauthorized to create suggestion for this employee",
//     });
//   }

//   try {
//     const pool = await getPool();
//     const result = await pool
//       .request()
//       .input("title", title)
//       .input("description", description)
//       .input("category", category)
//       .input("employee_id", employee_id)
//       .input("employee_name", employee_name)
//       .input("department", department)
//       .query(`
//         INSERT INTO suggestions (title, description, category, employee_id, employee_name, department, status, likes, dislikes, created_at)
//         OUTPUT INSERTED.*
//         VALUES (@title, @description, @category, @employee_id, @employee_name, @department, 'Pending', 0, 0, GETDATE())
//       `);

//     const newSuggestion = result.recordset[0];

//     res.status(201).json({
//       success: true,
//       message: "Suggestion added successfully",
//       data: newSuggestion,
//     });
//   } catch (err) {
//     console.error("Add Suggestion Error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to add suggestion",
//       error: err.message,
//     });
//   }
// });

// // PUT /:id/status (authenticated, admin/manager only)
// router.put("/:id/status", authenticateToken, async (req, res) => {
//   const { id } = req.params;
//   const { status, reviewed_by, comments } = req.body;

//   if (!status || !reviewed_by) {
//     return res.status(400).json({
//       success: false,
//       message: "Status and reviewed_by are required",
//     });
//   }

//   // Role check: Only admin/manager can update
//   if (!['admin', 'manager'].includes(req.user.role)) {
//     return res.status(403).json({
//       success: false,
//       message: "Only admins and managers can update suggestion status",
//     });
//   }

//   try {
//     const pool = await getPool();
//     const currentResult = await pool
//       .request()
//       .input("id", id)
//       .query("SELECT * FROM suggestions WHERE id = @id");

//     const currentSuggestion = currentResult.recordset[0];
//     if (!currentSuggestion) {
//       return res.status(404).json({
//         success: false,
//         message: "Suggestion not found",
//       });
//     }

//     await pool
//       .request()
//       .input("id", id)
//       .input("status", status)
//       .input("reviewed_by", reviewed_by)
//       .input("reviewed_at", new Date())
//       .input("review_comments", comments || null)
//       .query(`
//         UPDATE suggestions 
//         SET status = @status, 
//             reviewed_by = @reviewed_by, 
//             reviewed_at = @reviewed_at, 
//             review_comments = @review_comments
//         WHERE id = @id
//       `);

//     await pool
//       .request()
//       .input("suggestion_id", id)
//       .input("status", status)
//       .input("changed_by", reviewed_by)
//       .input("changed_at", new Date())
//       .input("comments", comments || null)
//       .query(`
//         INSERT INTO status_history (suggestion_id, status, changed_by, changed_at, comments)
//         VALUES (@suggestion_id, @status, @changed_by, @changed_at, @comments)
//       `);

//     res.json({
//       success: true,
//       message: "Suggestion status updated successfully",
//     });
//   } catch (err) {
//     console.error("Update Status Error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to update status",
//       error: err.message,
//     });
//   }
// });

// // Vote endpoints (already good, but add auth)
// router.post("/:id/vote", authenticateToken, async (req, res) => {
//   const { id } = req.params;
//   const { type, employee_id } = req.body;

//   if (!type || (type !== "like" && type !== "dislike")) {
//     return res.status(400).json({
//       success: false,
//       message: "Type must be 'like' or 'dislike'",
//     });
//   }

//   // Verify user from JWT
//   if (req.user.employee_id !== employee_id) {
//     return res.status(403).json({
//       success: false,
//       message: "Unauthorized to vote for this employee",
//     });
//   }

//   try {
//     const pool = await getPool();

//     await pool
//       .request()
//       .input("suggestion_id", id)
//       .input("employee_id", employee_id)
//       .query(`
//         DELETE FROM suggestion_votes 
//         WHERE suggestion_id = @suggestion_id 
//         AND employee_id = @employee_id
//       `);

//     await pool
//       .request()
//       .input("suggestion_id", id)
//       .input("employee_id", employee_id)
//       .input("vote_type", type)
//       .query(`
//         INSERT INTO suggestion_votes (suggestion_id, employee_id, vote_type)
//         VALUES (@suggestion_id, @employee_id, @vote_type)
//       `);

//     if (type === "like") {
//       await pool
//         .request()
//         .input("id", id)
//         .query("UPDATE suggestions SET likes = likes + 1 WHERE id = @id");
//     } else {
//       await pool
//         .request()
//         .input("id", id)
//         .query("UPDATE suggestions SET dislikes = dislikes + 1 WHERE id = @id");
//     }

//     res.json({
//       success: true,
//       message: `Suggestion ${type}d successfully`,
//     });
//   } catch (err) {
//     console.error("Vote Error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to vote",
//       error: err.message,
//     });
//   }
// });

// router.get("/:id/vote", authenticateToken, async (req, res) => {
//   const { id } = req.params;
//   const employeeId = req.user.employee_id; // From JWT

//   try {
//     const pool = await getPool();
//     const result = await pool
//       .request()
//       .input("suggestion_id", id)
//       .input("employee_id", employeeId)
//       .query(`
//         SELECT vote_type 
//         FROM suggestion_votes 
//         WHERE suggestion_id = @suggestion_id 
//         AND employee_id = @employee_id
//       `);

//     const vote = result.recordset[0];
//     res.json({
//       success: true,
//       data: vote ? vote.vote_type : null,
//     });
//   } catch (err) {
//     console.error("Get Vote Error:", err);
//     res.status(500).json({
//       success: false,
//       message: "Failed to fetch vote",
//       error: err.message,
//     });
//   }
// });

// module.exports = router;