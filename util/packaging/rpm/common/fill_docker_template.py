#!/usr/bin/env python3
import os
import argparse
from string import Template


class MyTemplate(Template):
    delimiter = "@@"


substitutions = dict()
substitutions[
    "ARGUMENTS"
] = """
ARG BASENAME=chapel
ARG CHAPEL_VERSION=2.1.0
ARG PACKAGE_VERSION=1
ARG OS_NAME
ARG DOCKER_DIR_NAME
ARG PARALLEL=1
ARG TARGETARCH
"""

substitutions["INJECT_BEFORE_DEPS"] = ""
inject = os.environ.get("INJECT_BEFORE_DEPS")
if inject is not None:
    substitutions["INJECT_BEFORE_DEPS"] = inject

substitutions[
    "USER_CREATION"
] = """
RUN useradd -ms /bin/bash user && \\
    usermod -aG wheel user && \\
    echo "user:password" | chpasswd && \\
    sed -i 's/%wheel[ \\t]\\{1,\\}ALL=(ALL)[ \\t]\\{1,\\}ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers

USER user
WORKDIR /home/user
"""

substitutions[
    "GET_CHAPEL"
] = """
COPY --chown=user ./tarballs/chapel-$CHAPEL_VERSION.tar.gz /home/user/chapel-$CHAPEL_VERSION.tar.gz
RUN tar xf chapel-$CHAPEL_VERSION.tar.gz
"""

substitutions[
    "BUILD_DEFAULT"
] = """
WORKDIR /home/user/chapel-$CHAPEL_VERSION
RUN export CHPL_HOME=/home/user/chapel-$CHAPEL_VERSION && \\
    rm -f $CHPL_HOME/chplconfig && touch $CHPL_HOME/chplconfig && \\
    ./configure --prefix=/usr && \\
    nice make all chpldoc mason chplcheck chpl-language-server -j$PARALLEL && \\
    unset CHPL_HOME
"""

substitutions["BUILD_GASNET_UDP"] = """
RUN export CHPL_HOME=/home/user/chapel-$CHAPEL_VERSION && \\
    rm -f $CHPL_HOME/chplconfig && touch $CHPL_HOME/chplconfig && \\
    echo "CHPL_COMM=gasnet" >> $CHPL_HOME/chplconfig && \\
    ./configure --prefix=/usr && \\
    nice make all chpldoc mason chplcheck chpl-language-server -j$PARALLEL && \\
    unset CHPL_HOME
"""

# TODO: remove `export CHPL_COMM_OFI_OOB=pmi2` when https://github.com/chapel-lang/chapel/issues/25236 is resolved
substitutions["BUILD_OFI_SLURM"] = """
RUN export CHPL_HOME=/home/user/chapel-$CHAPEL_VERSION && \\
    export CHPL_COMM_OFI_OOB=pmi2 && \\
    rm -f $CHPL_HOME/chplconfig && \\
    echo "CHPL_COMM=ofi" >> $CHPL_HOME/chplconfig && \\
    echo "CHPL_LAUNCHER=slurm-srun" >> $CHPL_HOME/chplconfig && \\
    echo "CHPL_COMM_OFI_OOB=pmi2" >> $CHPL_HOME/chplconfig && \\
    echo "CHPL_LIBFABRIC=bundled" >> $CHPL_HOME/chplconfig && \\
    ./configure --prefix=/usr && \\
    nice make all chpldoc mason chplcheck chpl-language-server -j$PARALLEL && \\
    unset CHPL_HOME && unset CHPL_COMM_OFI_OOB
"""

substitutions[
    "INSTALL"
] = """
USER root
RUN make install
USER user
"""

substitutions["PACKAGE_SETUP"] = """
WORKDIR /home/user

COPY --chown=user ./rpm/$DOCKER_DIR_NAME/spec.template /home/user/spec.template
COPY --chown=user ./rpm/common/make_spec.py /home/user/make_spec.py
COPY --chown=user ./common/package_name.py /home/user/package_name.py
RUN python3 make_spec.py $BASENAME $CHAPEL_VERSION $PACKAGE_VERSION $OS_NAME $TARGETARCH

COPY --chown=user ./rpm/common/rpmlintrc /home/user/.rpmlintrc
RUN rpmdev-setuptree && \\
    cp chapel-$CHAPEL_VERSION.tar.gz $(rpm --eval '%{_sourcedir}') && \\
    ignore_unused=$([[ "$(rpm --eval '%{?dist}')" == ".el9" ]] && echo "" || echo "--ignore-unused-rpmlintrc") && \\
    rpmlint $ignore_unused --file .rpmlintrc $BASENAME.spec && \\
    unset ignore_unused && \\
    spectool -g -R $BASENAME.spec

COPY --chown=user ./common/fixpaths.py /home/user/fixpaths.py
USER root
RUN python3 fixpaths.py $BASENAME $CHAPEL_VERSION $PACKAGE_VERSION $OS_NAME $TARGETARCH
USER user


# hot fixes for rpm, can be removed in 2.1
USER root
RUN short_version=$(python3 package_name.py --short-version $BASENAME $CHAPEL_VERSION $PACKAGE_VERSION $OS_NAME $TARGETARCH) && \
    sed -i 's|#!/usr/bin/env python|#!/usr/bin/env python3|' /usr/share/chapel/${short_version}/util/config/compileline.py && \
    unset short_version
USER user
"""

substitutions[
    "PACKAGE_BUILD"
] = """
RUN rpmbuild -ba $BASENAME.spec && \\
    cp $(rpm --eval '%{_rpmdir}')/$(rpm --eval '%{_arch}')/*.rpm .

FROM scratch as artifact
COPY --from=build /home/user/*.rpm /

FROM build as release
"""


def fill_docker_template(template_file):

    template = ""
    with open(template_file, "r") as f:
        template = f.read()

    src = MyTemplate(template)
    result = src.substitute(substitutions)

    dirname = os.path.dirname(template_file)
    output_file = os.path.join(dirname, "Dockerfile")
    with open(output_file, "w") as f:
        f.write(result)


def main():
    parser = argparse.ArgumentParser(description="Fill Docker template")
    parser.add_argument("template_file", type=str, help="Template file to fill")
    args = parser.parse_args()
    template_file = os.path.abspath(os.path.expanduser(args.template_file))
    fill_docker_template(template_file)


if __name__ == "__main__":
    main()
