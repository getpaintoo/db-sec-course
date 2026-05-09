const allowedSortFields = {
  title: "title",
  status: "status",
  priority: "priority",
  created_at: "created_at",
};

const allowedDirections = {
  asc: "ASC",
  desc: "DESC",
};

function buildVulnerableLoginQuery(username, passwordHash) {
  return `
    SELECT user_id, username, role_name
    FROM injection_lab.users
    WHERE is_active = true
      AND username = '${username}'
      AND password_hash = '${passwordHash}'
  `;
}

async function findUserByLogin(client, username, passwordHash) {
  const sql = `
    SELECT user_id, username, role_name
    FROM injection_lab.users
    WHERE is_active = true
      AND username = $1
      AND password_hash = $2
  `;

  return client.query(sql, [username, passwordHash]);
}

function buildVulnerableStatusQuery(status) {
  return `
    SELECT task_id, title, status, priority
    FROM injection_lab.tasks
    WHERE status = '${status}'
    ORDER BY created_at DESC
  `;
}

async function listTasksByStatus(client, status) {
  const sql = `
    SELECT task_id, title, status, priority
    FROM injection_lab.tasks
    WHERE status = $1
    ORDER BY created_at DESC
  `;

  return client.query(sql, [status]);
}

async function searchTasks(client, searchText) {
  const sql = `
    SELECT task_id, title, status, priority
    FROM injection_lab.tasks
    WHERE title ILIKE $1 OR description ILIKE $1
    ORDER BY created_at DESC
  `;

  return client.query(sql, [`%${searchText}%`]);
}

async function listTasks(client, sortBy = "created_at", direction = "desc") {
  const field = allowedSortFields[sortBy] ?? allowedSortFields.created_at;
  const sortDirection = allowedDirections[direction] ?? allowedDirections.desc;

  const sql = `
    SELECT task_id, title, status, priority, created_at
    FROM injection_lab.tasks
    ORDER BY ${field} ${sortDirection}
  `;

  return client.query(sql);
}

export {
  buildVulnerableLoginQuery,
  buildVulnerableStatusQuery,
  findUserByLogin,
  listTasksByStatus,
  listTasks,
  searchTasks,
};
