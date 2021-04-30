--微博数据表--
CREATE TABLE IF NOT EXISTS "T_Status" (
  "statusId" integer NOT NULL,
  "status" TEXT,
  "userId" INTEGER,
  PRIMARY KEY ("statusId")
);
