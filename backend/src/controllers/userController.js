const oracledb = require('oracledb');

const getUserProfile = async (req, res) => {
  let connection;
  try {
    const empId = req.params.empId || req.empId;
    
    connection = await oracledb.getConnection();
    const result = await connection.execute(
      `SELECT u.EMPID, u.name, u.email, u.dept_nm, 
              u.job_position_nm
       FROM pw_hr_emp_snapshot_t u WHERE u.EMPID = :empId`,
      { empId }
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = {
      empId: result.rows[0][0],
      name: result.rows[0][1],
      email: result.rows[0][3],
      department: result.rows[0][4],
      position: result.rows[0][5]
    };

    res.json(user);
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ message: 'Server error' });
  } finally {
    if (connection) {
      try { await connection.close(); } catch (err) { console.error(err); }
    }
  }
};

module.exports = { getUserProfile };