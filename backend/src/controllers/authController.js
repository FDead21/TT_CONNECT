const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const oracledb = require('oracledb');

const login = async (req, res) => {
    let connection;
    try {
        const { empId, pwd } = req.body;

        if (!empId || !pwd) {
            return res.status(400).json({ error: 'Employee ID and password are required.' });
        }

        connection = await oracledb.getConnection();
        const result = await connection.execute(
            `SELECT a.EMPID, b.NAME,  PWD FROM PW_ZZ_USER_T A JOIN PW_HR_EMP_SNAPSHOT_T B ON A.EMPID = B.EMPID AND HR_STATUS = 'A' AND PERS_SRCH_FLAG = 'Y' WHERE a.empid = :empId`,
            { empId: empId },
            { outFormat: oracledb.OUT_FORMAT_OBJECT }
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid Employee ID or password.' });
        }

        const user = result.rows[0];
        const saltedPassword = empId + pwd;
        const hash = crypto.createHash('sha256').update(saltedPassword).digest('base64');

        if (hash === user.PWD) {
            const token = jwt.sign(
                { empId: user.EMPID, name: user.NAME },
                process.env.JWT_SECRET,
                { expiresIn: '7d' }
            );

            res.json({
                message: 'Login successful!',
                token: token,
                user: {
                    empId: user.EMPID,
                    name: user.NAME,
                    department: user.DEPARTMENT,
                    position: user.POSITION,
                    email: user.EMAIL
                }
            });
        } else {
            res.status(401).json({ error: 'Invalid Employee ID or password.' });
        }
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ message: 'Server error during login.' });
    } finally {
        if (connection) {
            try { await connection.close(); } catch (err) { console.error(err); }
        }
    }
};

module.exports = { login };