## rpkg tips
if a copr build fails, then you can try to fix the problem locally as follows.
requires running a fedora-like operating system!

1. **configure**
   ```shell
   MOMMY_RESULTS="/tmp/rpkg-results/"
   MOMMY_PLATFORM="fedora-44-x86_64"
   ```
   obviously, configure `MOMMY_PLATFORM` to whatever platform you're trying to reproduce~
2. **download**
   ```shell
   git clone git@github.com:fwdekker/mommy.git
   ```
3. **point rpkg to local build**
   ```shell
   # run this from the git repository's root directory
   mv pkg/rpkg/* ./
   sed -i 's|git_repo_|git_dir_|g' mommy.spec.rpkg
   sed -i 's|pkg/rpkg/rpkg.macros|rpkg.macros|g' rpkg.conf
   ```
   yes, you really _must_ move the `.spec.rpkg` and related files into the project's root.
   copr has cool tools that work with putting the `.spec.rpkg` in a different directory, but the method we're using here doesn't!
4. **make local changes**  
   make changes to the project that hopefully fix the build error.
   skip this step if you're just trying to reproduce the error seen on copr.
5. **build locally**
   ```shell
   # run this from the git repository's root directory
   rm -rf "$MOMMY_RESULTS"
   MOMMY_SRC_RPM="$(rpkg srpm 2>/dev/null | grep '^Wrote: .*\.src\.rpm$' | sed 's|Wrote: ||g')"
   mock -r "$MOMMY_PLATFORM" --rebuild "$MOMMY_SRC_RPM" --resultdir "$MOMMY_RESULTS" --enable-network
   ```
   tip: append option `-N` to not clean up `$MOMMY_RESULTS` afterwards!
6. **point rpkg to remote sources again**  
   when you're done debugging, run
   ```shell
   # run this from the git repository's root directory
   sed -i 's|rpkg.macros|pkg/rpkg/rpkg.macros|g' rpkg.conf
   sed -i 's|git_dir_|git_repo_|g' mommy.spec.rpkg
   mv *rpkg* pkg/rpkg/
   ```
