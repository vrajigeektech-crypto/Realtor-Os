-- If uploads work but public URLs return:
-- {"statusCode":"404","error":"Bucket not found","message":"Bucket not found"}
-- it usually means the bucket exists but is NOT public.
--
-- Run once in Supabase SQL Editor.

UPDATE storage.buckets
SET public = true
WHERE id = 'user_assets';

-- Optional: confirm
SELECT id, name, public
FROM storage.buckets
WHERE id = 'user_assets';

