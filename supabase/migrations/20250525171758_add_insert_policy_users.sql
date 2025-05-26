-- Allow users to insert their own row in users table
create policy "Users can insert their own data"
  on public.users for insert
  with check (auth.uid() = id); 