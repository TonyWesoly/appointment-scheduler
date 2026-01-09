package com.github.TonyWesoly.appointment_scheduler.repository;

import com.github.TonyWesoly.appointment_scheduler.model.Availability;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AvailabilityRepository extends JpaRepository <Availability,Long> {
}
