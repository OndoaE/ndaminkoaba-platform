-- Prevent duplicate certificates for the same user+course under concurrent
-- claim requests (was previously enforced only by a check-then-create race
-- in application code).
CREATE UNIQUE INDEX "Certificate_userId_courseId_key" ON "Certificate"("userId", "courseId");
