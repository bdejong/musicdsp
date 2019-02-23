Parallel combs delay calculation
================================

- **Author or source:** Juhana Sadeharju ( if.tenuf.cin@aihuok )
- **Created:** 2002-05-23 19:49:40


.. code-block:: text
    :caption: notes

        This formula can be found from a patent related to parallel combs structure. The
    formula places the first echoes coming out of parallel combs to uniformly distributed
    sequence. If T_ ,...,T_n are the delay lines in increasing order, the formula can be
    derived by setting T_(k-1)/T_k = Constant and T_n/(2*T_1) = Constant, where 2*T_1 is the
    echo coming just after the echo T_n.
        I figured this out myself as it is not told in the patent. The formula is not the best
    which one can come up. I use a search method to find echo sequences which are uniform
    enough for long enough time. The formula is uniform for a short time only.
        The formula doesn't work good for series allpass and FDN structures, for which a
    similar formula can be derived with the same idea. The search method works for these
    structures as well.



